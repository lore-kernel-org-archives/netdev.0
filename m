From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sun, 15 Jan 2006 21:05:33 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0601152038540.19953@irie>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com>
 <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com>
 <1137191522.2520.63.camel@localhost> <20060114011726.GA19950@shaftnet.org>
 <43C97605.9030907@pobox.com> <20060115152034.GA1722@shaftnet.org>
Reply-To: samuel.ortiz@nokia.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750850AbWAOVGB@vger.kernel.org>
To: ext Stuffed Crust <pizza@shaftnet.org>
In-Reply-To: <20060115152034.GA1722@shaftnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Jan 2006, ext Stuffed Crust wrote:

>  * Knowing the hardware frequency capabilities, the 802.11 stack applies
>    802.11d and regdomain rules to the available frequency set, and
Regarding 802.11d and regulatory domains, the stack should also be able to
stick to one regulatory domain if asked so by userspace, whatever the APs
around tell us.

Cheers,
Samuel.
