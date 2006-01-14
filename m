From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sat, 14 Jan 2006 14:47:54 +0100
Message-ID: <m3psmu9b05.fsf@defiant.localdomain>
References: <20060113195723.GB16166@tuxdriver.com>
	<20060113212605.GD16166@tuxdriver.com>
	<20060113213011.GE16166@tuxdriver.com>
	<20060113221935.GJ16166@tuxdriver.com>
	<1137191522.2520.63.camel@localhost>
	<20060114011726.GA19950@shaftnet.org>
	<1137230889.2520.82.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stuffed Crust <pizza@shaftnet.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932743AbWANNsH@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1137230889.2520.82.camel@localhost> (Johannes Berg's message of "Sat, 14 Jan 2006 10:28:09 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> writes:

> Yeah, this is about what I thought of -- and it makes me wonder if the
> stack really should be aware of the channelization, or if the WiPHY
> driver might better just handle it itself.

The latter, possibly using library functions from the stack :-)
-- 
Krzysztof Halasa
