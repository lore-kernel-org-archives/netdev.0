From: "David S. Miller" <davem@redhat.com>
Subject: Re: Anycast usage, final diagnosis? (was: IPv6: Fix broken anycast
Date: Thu, 17 Jul 2003 14:51:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030717145115.046fd5ee.davem@redhat.com>
References: <Pine.LNX.4.44.0307171340160.4378-100000@netcore.fi>
	<200307172052.AAA15032@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, mika.liljeberg@welho.com, jmorris@redhat.com,
   netdev@oss.sgi.com, dlstevens@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307172052.AAA15032@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Jul 2003 00:52:03 +0400 (MSD)
kuznet@ms2.inr.ac.ru wrote:

> > No user should be able to join anycast group, IMHO.
> 
> OK. Done, the patch enclosed.

Pekka, please ACK Alexey's patch, I'd like to apply it.

Thanks.
