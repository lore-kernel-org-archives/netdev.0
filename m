From: "Ioan Ionita" <opslynx@gmail.com>
Subject: Re: sky2 patch in 2.6.24-rc7-git6 breaks POST - commit 84cd2dfb04d23a961c5f537baa243fa54d0987ac
Date: Tue, 15 Jan 2008 21:00:13 +0200
Message-ID: <df47b87a0801151100qe7c39f1y3296176f343667eb@mail.gmail.com>
References: <df47b87a0801150301w6b970decwdd4bd256aa2ca9ac@mail.gmail.com>
	 <20080115100947.4ec6cda0@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "Stephen Hemminger" <stephen.hemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757366AbYAOTAq@vger.kernel.org>
In-Reply-To: <20080115100947.4ec6cda0@deepthought>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jan 15, 2008 8:09 PM, Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:
> On Tue, 15 Jan 2008 13:01:47 +0200
> "Ioan Ionita" <opslynx@gmail.com> wrote:
>

>
> Is Wake On Lan enabled in the BIOS?

I don't have a Wake on Lan option in BIOS, only wake on pci, i assume
it's the same.  It was disabled. I enabled it and the regression
behaved the same way.  Wouldn't POST after shutdown or soft reset.

Regards
