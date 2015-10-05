From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: Request for stable-4.1.y stable inclusion
Date: Mon, 05 Oct 2015 15:01:55 -0400
Message-ID: <1444071715.3494.53.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

Could you please backport the following to stable-4.1.y:

	commit 74e98eb085889b0d2d4908f59f6e00026063014f -- RDS: verify
	the underlying transport exists before creating a connection

	This fixes CVE-2015-6937.

	commit 48900cb6af4282fa0fb6ff4d72a81aa3dadb5c39 -- virtio-net:
	drop NETIF_F_FRAGLIST

	This fixes CVE-2015-5156.

Thanks!
