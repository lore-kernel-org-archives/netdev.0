From: kuznet@ms2.inr.ac.ru
Subject: Re: [patch] bug prematurely setting nr_frags
Date: Mon, 12 Aug 2002 01:07:33 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208112107.BAA16136@sex.inr.ac.ru>
References: <20020809161439.E10640@redhat.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: bcrl@redhat.COM (Benjamin LaHaise)
In-Reply-To: <20020809161439.E10640@redhat.com> from "Benjamin LaHaise" at Aug 11, 2 02:45:07 am
List-Id: netdev.vger.kernel.org

Hello!

> that comes from an uninitialized fragment entry in an skb, and this problem 
> looks like a possible causes.

This function is not used, by the way.

Alexey
