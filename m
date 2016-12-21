From: Mark Greer <mgreer@animalcreek.com>
Subject: Re: [PATCH 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt IO
 voltage
Date: Wed, 21 Dec 2016 09:13:57 -0700
Message-ID: <20161221161357.GA15927@animalcreek.com>
References: <1482250592-4268-1-git-send-email-glansberry@gmail.com>
 <1482250592-4268-2-git-send-email-glansberry@gmail.com>
 <20161221022347.GB5444@animalcreek.com>
 <32FAB08E-BE8E-4127-80A6-013300B43BD0@kuvee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, lauro.venancio@openbossa.org,
        aloisio.almeida@openbossa.org, sameo@linux.intel.com,
        robh+dt@kernel.org, mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        justin@kuvee.com
To: Geoff Lansberry <geoff@kuvee.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <32FAB08E-BE8E-4127-80A6-013300B43BD0@kuvee.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 06:47:36AM -0500, Geoff Lansberry wrote:
> Thanks Mark.   Should I resubmit patches with the requested edits today, or wait a bit for more comments?  What is the desired etiquette?

Its up to you.  I don't think there are any hard & fast rules on this.

If it were me, I would likely spin a new version today because there are
several responses already and it lets people review them at their leisure
over the holidays.

Just a thought - you may want to consider separating the third patch from
the other two.  The problems the first two solve are well understood and
have reasonable solutions (I believe).  The third one - for me, at least -
tries to fix a problem that is not well understood yet.

Mark
--
