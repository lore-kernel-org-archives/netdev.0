From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH 00/24] TRILL implementation
Date: Wed, 24 Sep 2014 10:24:32 -0700
Message-ID: <CAHA+R7MmcxKK2F3y7tkHxD7ZvK+WkJDevLz=vOEr6QScngBkbw@mail.gmail.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
	<20140924094422.2e710ead@urahara>
	<20140924165447.GG27183@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Ahmed Amamou <ahmed@gandi.net>,
	netdev <netdev@vger.kernel.org>, f.cachereul@alphalink.fr,
	Fengguang Wu <fengguang.wu@intel.com>
To: William Dauchy <william@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:32770 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbaIXRYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 13:24:33 -0400
Received: by mail-la0-f44.google.com with SMTP id gi9so808128lab.31
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 10:24:32 -0700 (PDT)
In-Reply-To: <20140924165447.GG27183@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 9:54 AM, William Dauchy <william@gandi.net> wrote:
> On Sep24 09:44, Stephen Hemminger wrote:
>> Is this patch series bisectable? does it build at each step?
>
> it should be the case but we will double check that.
>

You can ask Fengguang to add your repo to his kbuild bot,
I am sure it can catch much more than we do. :)
