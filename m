From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable
Date: Tue, 7 Oct 2003 03:40:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007034051.3fcb3218.davem@redhat.com>
References: <200310011637.27013.mashirle@us.ibm.com>
	<200310071038.OAA30009@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200310071038.OAA30009@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Oct 2003 14:38:50 +0400 (MSD)
kuznet@ms2.inr.ac.ru wrote:

> Please, do not use "long" things, they are not allowed in API.
> u32 would be good.

Do you think it is large enough for timestamp? :)
