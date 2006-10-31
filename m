From: Stephen Hemminger <shemminger@osdl.org>
Subject: TCP congestion graphs (2.6.19-rc4)
Date: Tue, 31 Oct 2006 12:00:16 -0800
Message-ID: <20061031120016.75dc4c3c@freekitty>
References: <20061025110207.78d38779@freekitty>
	<000701c6f885$b57aa390$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Sangtae Ha" <sha2@ncsu.edu>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4485 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1945956AbWJaUAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 15:00:37 -0500
To: "Injong Rhee" <rhee@eos.ncsu.edu>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <000701c6f885$b57aa390$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I reran the tests, this time using my DSL line to home (80ms 1Mbit/sec).
	http://developer.osdl.org/shemminger/tcp/2.6.19-rc4/dsl

The only obvious problem is Vegas looks broken.
