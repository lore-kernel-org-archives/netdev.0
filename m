From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFT 0/3] cxgb4: use request_firmware_nowait()
Date: Wed, 25 Jun 2014 17:08:15 -0700
Message-ID: <CAB=NE6UfmSY2xVtb3Khs7ZxLCSWfr0u7bXaQGdfDFK2=58Atiw@mail.gmail.com>
References: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com>
 <53A87AC8.7010305@chelsio.com> <20140624002941.GD27687@wotan.suse.de>
 <53A99F71.2060308@chelsio.com> <53A9A88B.2000006@chelsio.com>
 <20140624233951.GH27687@wotan.suse.de> <20140625020019.GJ27687@wotan.suse.de> <20140625215113.GA27687@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	Philip Oswald <poswald@suse.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Jeffrey Cheung <jcheung@suse.com>,
	David Chang <dchang@suse.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140625215113.GA27687@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 2:51 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
> I'll go ahead and test this on the other
> distribution you mentioned you had issues, curious what could trigger a timeout
> failure there that would be distribution specific.

I've tested this on SLE12 and see no issues as well.

  Luis
