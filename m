From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Mon, 19 Nov 2007 23:04:24 +0100
Message-ID: <200711192304.25087.rjw@sisk.pl>
References: <20071119191000.GA1560@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755146AbXKSVq6@vger.kernel.org>
In-Reply-To: <20071119191000.GA1560@elf.ucw.cz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 19 of November 2007, Pavel Machek wrote:
> Hi!
> 
> I think that this worked before:
> 
> root@amd:/proc# find . -name "timer_info"
> find: WARNING: Hard link count is wrong for ./net: this may be a bug
> in your filesystem driver.  Automatically turning on find's -noleaf
> option.  Earlier results may have failed to include directories that
> should have been searched.
> root@amd:/proc#

I'm seeing that too.

Rafael
