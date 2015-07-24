From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH V3 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock
 packet and get the r/w-ability
Date: Fri, 24 Jul 2015 11:33:47 +0300
Message-ID: <20150724083347.GV5371@mwanda>
References: <1437476293-6837-1-git-send-email-decui@microsoft.com>
 <87zj2pk3jf.fsf@vitty.brq.redhat.com>
 <4538264677374d43961c2d709afb1dd3@SIXPR30MB031.064d.mgd.msft.net>
 <20150722103546.GO5371@mwanda>
 <75f1792c788e418eaddc0d6b7e3381de@SIXPR30MB031.064d.mgd.msft.net>
 <20150723101057.GQ5371@mwanda> <20150723102449.GR5371@mwanda>
 <20150724062701.GA5525@sudip-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20150724062701.GA5525@sudip-PC>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Fri, Jul 24, 2015 at 11:57:01AM +0530, Sudip Mukherjee wrote:
> This is also ok, the function is supposed to return ret or-ed with the
> relevant flags based on the scan position. It is considered error if 0
> is returned (without any flag).

Yeah.  You're right.  I looked through my list again this morning and
they all seem fine...

regards,
dan carpenter
