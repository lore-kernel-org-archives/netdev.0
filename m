From: "Johannes Berg" <johannes@sipsolutions.net>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sun, 15 Jan 2006 16:51:32 +0100 (CET)
Message-ID: <56187.84.135.205.30.1137340292.squirrel@secure.sipsolutions.net>
References: <20060113195723.GB16166@tuxdriver.com>
    <20060113221935.GJ16166@tuxdriver.com>
    <1137191522.2520.63.camel@localhost>
    <200601151340.10730.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932090AbWAOPvq@vger.kernel.org>
In-Reply-To: <200601151340.10730.stefan@loplof.de>
To: "Stefan Rompf" <stefan@loplof.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Rompf wrote:

> Even though it is a bit more work on kernel side, we should allow changing
> the
> mode of virtual devices. Let's face it, even though we find multi-BSS
> capabilities very interesting, 999 of 1000 users won't care due to the two
> facts that IPW firmware IMHO doesn't allow it and virtual interfaces are
> limited to one channel anyway. These users rightfully expect to have one
> interface and be able to do all configurations on it.

Isn't that rather a question of having good user-space tools that make
deactivating one type of interface and activating another seamless?

johannes
