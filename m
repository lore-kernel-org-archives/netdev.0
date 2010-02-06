From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Some fixes and cleanups for DMFE nework driver
Date: Sat,  6 Feb 2010 22:18:56 +0200
Message-ID: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I recently put out of the closed my old davicom card and found out
that it doesn't work in my new PC.

Here are few fixes and coding style cleanups for this driver

Without patch #3 the card refuses to work at all here.

First patch is quite large, but it doesn't add any functionality but
makes whole driver pass checkpatch.pl

I also update and fix my own code for suspend/resume and WOL.

Best regards,
	Maxim Levisky
