From: kuznet@ms2.inr.ac.ru
Subject: Re: Frozen machine with adding a tc filter
Date: Wed, 24 Jul 2002 01:56:22 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207232156.BAA16799@sex.inr.ac.ru>
References: <20020723212803.GA14546@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: albertogli@telpin.COM.AR, netdev@oss.sgi.com, jdike@karaya.com
Return-path: <owner-netdev@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20020723212803.GA14546@outpost.ds9a.nl> from "bert hubert" at Jul 23, 2 11:28:04 pm
List-Id: netdev.vger.kernel.org

Hello!

> However, with the commandlines specified, the classifier returns.. head,

This is strange. cbq_bind_filter() is supposed to return nil class,
unless reference has deeper level.

Alexey
