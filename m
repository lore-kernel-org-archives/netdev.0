From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: Linux 2.6.7
Date: Wed, 16 Jun 2004 13:13:29 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040616111329.GA1571@louise.pinerecords.com>
References: <Pine.LNX.4.58.0406152253390.6392@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266241AbUFPLNl@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0406152253390.6392@ppc970.osdl.org>
List-Id: netdev.vger.kernel.org

On Jun-15 2004, Tue, 22:56 -0700
Linus Torvalds <torvalds@osdl.org> wrote:

> Summary of changes from v2.6.7-rc3 to v2.6.7
[snip]

2.6.7's airo.ko (unlike 2.6.6's) won't allow the user to set
ESSID via "echo myessid >/proc/driver/aironet/ethX/SSID".

Changes like this shouldn't probably be made in the middle
of a stable series.

-- 
Tomas Szepe <szepe@pinerecords.com>
