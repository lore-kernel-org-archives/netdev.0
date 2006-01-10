From: "Johannes Berg" <johannes@sipsolutions.net>
Subject: Re: State of the Union: Wireless
Date: Tue, 10 Jan 2006 14:18:39 +0100 (CET)
Message-ID: <37204.131.234.108.55.1136899119.squirrel@secure.sipsolutions.net>
References: <20060106042218.GA18974@havoc.gtf.org>
    <1136547084.4037.41.camel@localhost>
    <200601071649.35321.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932207AbWAJNTF@vger.kernel.org>
In-Reply-To: <200601071649.35321.vda@ilport.com.ua>
To: "Denis Vlasenko" <vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Vlasenko wrote:

> I am confused.

Which isn't really all that surprising.

> ftp://ftp.berlios.de/pub/bcm43xx/snapshots/softmac/ieee80211softmac-20060107.tar.bz2
> which is not the same. For example, ieee80211softmac.h file exists in both
> tarballs but is not identical.
>
> Suppose one wants to use softmac in a project. What tarball contains
> the bleeding edge of softmac?

The one from the softmac page is created from the git repository. The one
on the bcm page is created from the now historical mercurial archive.

I need to get the bcm people to take away that snapshot and link to the
correct one.

johannes
