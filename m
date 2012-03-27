From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Tue, 27 Mar 2012 17:33:45 +0200
Message-ID: <20120327153345.GA13948@localhost.localdomain>
References: <02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
 <20120322064107.GB2182@netboy.at.omicron.at>
 <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
 <20120324065147.GB2201@netboy.at.omicron.at>
 <CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
 <20120326152730.GA10212@localhost.localdomain>
 <CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:56330 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab2C0PeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 11:34:00 -0400
Received: by wejx9 with SMTP id x9so17147wej.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 08:33:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 01:11:32PM -0400, chetan loke wrote:
> 
> Why isn't ioctl-rate limiting acceptable?

Let me turn the question around.

What other kernel subsystem rate limits ioctls?

Richard
