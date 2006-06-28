From: James Morris <jmorris@namei.org>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (minor fix)
Date: Wed, 28 Jun 2006 10:00:48 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606281000150.12544@d.namei>
References: <20060628053432.GA27226@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, jmorris@redhat.com,
	chrisw@osdl.org, herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, akpm@osdl.org, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:64680 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1423333AbWF1OAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 10:00:51 -0400
To: Catherine Zhang <cxzhang@watson.ibm.com>
In-Reply-To: <20060628053432.GA27226@jiayuguan.watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Jun 2006, Catherine Zhang wrote:

> Hi,
> 
> Minor fix (un-export selinux_get_sock_sid()).

Thanks, looks ok to me.

Acked-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
