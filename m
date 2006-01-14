From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: wireless: recap of current issues (other issues)
Date: Sat, 14 Jan 2006 17:09:23 -0500
Message-ID: <43C97693.7000109@pobox.com>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213237.GH16166@tuxdriver.com> <20060113222408.GM16166@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751324AbWANWJ1@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060113222408.GM16166@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Other Issues
> ============

A big open issue:  should you fake ethernet, or represent 802.11 
natively throughout the rest of the net stack?

The former causes various and sundry hacks, and the latter requires that 
you touch a bunch of non-802.11 code to make it aware of a new frame class.

	Jeff
