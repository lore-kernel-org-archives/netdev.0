From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 10:10:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008101046.376abc3b.davem@redhat.com>
References: <3F844578.40306@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnip@sgi.com
In-Reply-To: <3F844578.40306@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Oh yeah?  What are your numbers like if you just disable the ia64
kernel unaligned access printk()?
