From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: bugfix: wireless bug causing working setups to loose net
	connectivity
Date: Tue, 22 Sep 2009 00:24:53 -0400
Message-ID: <20090922042452.GC2688@tuxdriver.com>
References: <200909212035.50592.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45038 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbZIVEaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 00:30:52 -0400
Content-Disposition: inline
In-Reply-To: <200909212035.50592.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2009 at 08:35:50PM +0200, Arkadiusz Miskiewicz wrote:
> 
> Could 
> http://marc.info/?l=linux-wireless&m=125323296617306&w=2 
> be merged without waiting for separate wireless pull request?
> 
> Currently previously working setups are no longer able to connect to AP (in my 
> case WPA2PSK via wpasupplicant).
> 
> AFAIK there was some kind of policy where bugfixes that break basic 
> functionality are supposed to be merged fast to allow to actually use and test 
> git kernel.

I'll make sure to include this in the next pull request, probably
tomorrow.  Sorry, I'm too tired tonight.  FWIW, I'm traveling ATM...

Hth!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
