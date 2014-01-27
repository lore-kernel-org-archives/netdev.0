From: zhuyj <zyjzyj2000@gmail.com>
Subject: How to identify 6to4 and 6in4 tunnels
Date: Mon, 27 Jan 2014 18:39:53 +0800
Message-ID: <52E63779.5090101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	zhuyj <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Maintainers

In our scene, we will create the 6in4/6to4 tunnel firstly and need to=20
check the tunnel type, secondly, we will configure the ip address on it=
=2E=20
So, Could we have any way to get the actual tunnel for 6in4 and 6to4=20
from current linux version?

Both 6in4 and 6to4 have the same protocol =93IPPROTO_IPV6=94 in Linux=20
kernel. The only difference is the ip address on the tunnel. Can we=20
distinguish them in Linux kernel?

Best Regards

Zhu Yanjun
