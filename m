From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Drivers: isdn: hisax: isac.c: Fix assignment and check
 into one expression.
Date: Sun, 27 Mar 2016 22:43:27 -0400 (EDT)
Message-ID: <20160327.224327.429120851380462276.davem@davemloft.net>
References: <1458953390-7306-1-git-send-email-gabrielcsmo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gabrielcsmo@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458953390-7306-1-git-send-email-gabrielcsmo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>
Date: Sat, 26 Mar 2016 02:49:50 +0200

> Fix variable assignment inside if statement. It is error-prone and hard to read.
> 
> Signed-off-by: Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>

Applied.
