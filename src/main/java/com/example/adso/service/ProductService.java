package com.example.adso.service;

import com.example.adso.model.Product;
import com.example.adso.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;

    /**
     * Devuelve todos los productos.
     */
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    /**
     * Crea un nuevo producto.
     */
    public Product createProduct(Product product) {
        return productRepository.save(product);
    }
}
