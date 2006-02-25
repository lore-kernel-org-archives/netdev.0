From: Olaf Hering <olh@suse.de>
Subject: Re: [2.6 patch] make UNIX a bool
Date: Sat, 25 Feb 2006 23:46:31 +0100
Message-ID: <20060225224631.GA4085@suse.de>
References: <20060225160150.GX3674@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932199AbWBYWqi@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060225160150.GX3674@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 On Sat, Feb 25, Adrian Bunk wrote:

> CONFIG_UNIX=m doesn't make much sense.

There is likely more code to support a modular unix.ko, this has to go
as well.
