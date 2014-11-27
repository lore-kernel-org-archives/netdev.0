From: Rajib Karmakar <rajibkit@gmail.com>
Subject: Re: Multiple DSA switch on shared MII
Date: Thu, 27 Nov 2014 12:48:35 +0530
Message-ID: <CAOi_9k9h4N-uPf7shapytV+rCtHFWiVco26hCVjTMN=00o8KAg@mail.gmail.com>
References: <CAOi_9k8NwpVFxg=9VOagVt3m6hn2uLKuCZ_0-+4PciJNRWuTmA@mail.gmail.com>
	<CAGVrzcaG_uYpmmgC252ObHJ9Cmt91-BUtB3uOfPJHV6RhkRU1Q@mail.gmail.com>
	<CAOi_9k8WySmjm5cdFn1kJQuE7cJ1rDyM9SV2RvbcmbB+UeTVdQ@mail.gmail.com>
	<547636B7.3060706@gmail.com>
	<CAOi_9k_3+9U4q=SHdeEJOi_efHkRvYdTQ=UBqZtafgDAv_oOHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:65454 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaK0HSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 02:18:36 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so4458122pad.31
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 23:18:36 -0800 (PST)
In-Reply-To: <CAOi_9k_3+9U4q=SHdeEJOi_efHkRvYdTQ=UBqZtafgDAv_oOHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This could be a naive question; but can I add all LAN and WAN
interfaces in a single DSA switch (one cpu port, one netdev)?
