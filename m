From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: wireless-2.6 (was: [PATCH] wpa_supplicant: update
	driver_prism54.c)
Date: Sun, 29 Aug 2004 23:12:35 -0700
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040830061235.GB7415@jm.kir.nu>
References: <20040819232720.GD6044@ruslug.rutgers.edu>
	<20040820024645.GA7154@jm.kir.nu> <413114FA.2000609@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: prism54-devel@prism54.org, hostap@shmoo.com, netdev@oss.sgi.com
Return-path: <prism54-devel-bounces@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <413114FA.2000609@pobox.com>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 28, 2004 at 07:27:54PM -0400, Jeff Garzik wrote:

> Am I ever going to see an update to HostAP in wireless-2.6?

I sure hope so. Unfortunately, there have been couple of things delaying
this on my part. One being lack of time (or not being on top of the
priority list), another being wait for getting a resolution for somewhat
related negotiations with my current employer.

Time/priority part is hopefully getting better. I wanted to first finish
the proposal for adding WPA/WPA2 to wireless extensions, but that is
starting to be near completion. After this, working on cleaning up the
generic IEEE 802.11 code in Host AP driver would be quite good next
project. If you are willing to add WE-18 first to wireless-2.6, I could
easily send you patches for this (both for adding WE-18 and to make Host
AP use it).

The other delaying factor is a bit more complicated. My current employer
happens to be involved with very similar areas as wireless-2.6
development and I need to be a bit careful on what I'm doing on my
free time. I took care of getting written agreement about Host AP
development before joining the company (lucky me ;-), but future
wireless-2.6 changes are starting to get beyond this. I had hoped to get
this resolved long time ago. However, getting a new agreement about
extended area (like wireless-2.6) has unfortunately already taken way
more than enough time and is still ongoing.

Apparently, I will have to start pushing more on this to actually
get some kind of conclusion so that I could start working more actively
with wireless-2.6. If nothing else works, I may have to start looking
for a new employer in order to be able to work with wireless-2.6..

-- 
Jouni Malinen                                            PGP id EFC895FA
