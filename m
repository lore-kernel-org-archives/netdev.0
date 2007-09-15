From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: 2.6.23-rc6: known regressions with patches v2
Date: Sat, 15 Sep 2007 04:29:11 +0200
Message-ID: <46EB4377.7040200@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Satyam Sharma <satyam.sharma@gmail.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	linux-acpi@vger.kernel.org, Len Brown <lenb@kernel.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Alexey Starikovskiy <aystarik@gmail.com>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg KH <gregkh@suse.de>,
	Anssi Hannula <anssi.hannula@gmail.com>,
	Christian Kujau <lists@nerdbynature.de>,
	jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc6
with patches available.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            10
Andi Kleen                             7
Linus Torvalds                         6
Alan Stern                             5
Hugh Dickins                           5
Trond Myklebust                        5
Andrew Morton                          4
David S. Miller                        4
Al Viro                                3
Alexey Starikovskiy                    3
Cornelia Huck                          3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



Unclassified

Subject         : Oops while modprobing phy fixed module
References      : http://lkml.org/lkml/2007/7/14/63
Last known good : ?
Submitter       : Gabriel C <nix.or.die@googlemail.com>
Caused-By       : ?
Handled-By      : Satyam Sharma <satyam.sharma@gmail.com>
                  Vitaly Bordug <vitb@kernel.crashing.org>
Patch1          : http://lkml.org/lkml/2007/7/18/506
Status          : patch available



ACPI

Subject         : 2.6.23-rc5 hangs on boot, apparently when initializing the EC
References      : http://lkml.org/lkml/2007/9/11/369
Last known good : ?
Submitter       : Chuck Ebbert <cebbert@redhat.com>
Caused-By       : ?
Handled-By      : Alexey Starikovskiy <aystarik@gmail.com>
Patch           : http://bugzilla.kernel.org/attachment.cgi?id=12673
Status          : patch was suggested



Drivercore

Subject         : sysfs change of input/event devices in 2.6.23rc breaks udev
References      : http://lkml.org/lkml/2007/9/8/86
Last known good : ?
Submitter       : Anssi Hannula <anssi.hannula@gmail.com>
Caused-By       : ?
Handled-By      : Dmitry Torokhov <dmitry.torokhov@gmail.com>
Patch           : http://lkml.org/lkml/2007/9/10/3
Status          : patch available



Networking

Subject         : 2.6.23-rc5: possible irq lock inversion dependency detected
References      : http://lkml.org/lkml/2007/9/2/97
Last known good : ?
Submitter       : Christian Kujau <lists@nerdbynature.de>
Caused-By       : ?
Handled-By      : jamal <hadi@cyberus.ca>
Patch           : http://lkml.org/lkml/2007/9/11/159
Status          : patch available



Farewell!
Michal

--
LOGOUT
http://www.stardust.webpages.pl/
