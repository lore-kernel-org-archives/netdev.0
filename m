From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH] net: Delay default_device_exit_batch until no devices are
 unregistering v2
Date: Tue, 24 Sep 2013 10:54:30 -0700
Message-ID: <CA+HUmGji3ujdD9nXLVVcXc8_KOGvjOU2CVHxYsh70q1G99PA5g@mail.gmail.com>
References: <e652a11e-b23d-4a83-aaac-00c469a416f1@email.android.com>
	<20130917.201515.1404443973169590392.davem@davemloft.net>
	<CA+HUmGgg3-0UNgfKS6Hpnczzi6PUeztk8TZ7p_97kcvtfMacJQ@mail.gmail.com>
	<20130917.235247.344101545141336143.davem@davemloft.net>
	<87a9j26eca.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:58331 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499Ab3IXRyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 13:54:31 -0400
Received: by mail-ve0-f177.google.com with SMTP id db12so3718109veb.22
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 10:54:30 -0700 (PDT)
In-Reply-To: <87a9j26eca.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch looks fine to me.
Thanks again for looking into this.

Francesco
