From: Ionut Leonte <ionut.leonte@gmail.com>
Subject: Re: [PATCH] b44: GFP_DMA skb should not escape from driver
Date: Thu, 15 Jan 2009 19:14:11 +0200
Message-ID: <200901151914.11421.ionut.leonte@gmail.com>
References: <20090115111537.GA994@gondor.apana.org.au> <496F4AD4.9080201@cosmosbay.com> <496F690A.2090606@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Pekka Pietikainen <pp@ee.oulu.fi>,
	Mihai =?utf-8?q?Don=C8=9Bu?= <mihai.dontu@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760236AbZAORPp@vger.kernel.org>
In-Reply-To: <496F690A.2090606@cosmosbay.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applied, seems to fix the problem.
