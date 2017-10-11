From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: sched: get rid of
 cls_flower->egress_dev
Date: Wed, 11 Oct 2017 08:44:46 +0200
Message-ID: <20171011064446.GA2039@nanopsycho>
References: <20171010073016.3682-1-jiri@resnulli.us>
 <CAJ3xEMgPdcVrogHZmEnH+vP3E53zvEcFN8+wyuEqSs6utHQVRg@mail.gmail.com>
 <20171010211357.GJ2033@nanopsycho>
 <CAJ3xEMizUNPzPAjWuk-PpkK88UgD9OmOGORiEO64r0dx-GfcBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        mlxsw <mlxsw@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33090 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdJKGot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 02:44:49 -0400
Received: by mail-wr0-f193.google.com with SMTP id z96so458315wrb.0
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 23:44:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMizUNPzPAjWuk-PpkK88UgD9OmOGORiEO64r0dx-GfcBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 10, 2017 at 11:46:22PM CEST, gerlitz.or@gmail.com wrote:
>On Wed, Oct 11, 2017 at 12:13 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Oct 10, 2017 at 07:24:21PM CEST, gerlitz.or@gmail.com wrote:
>
>> Or, as I replied to you earlier, the issue you describe is totally
>> unrelated to this patchset as you see the issue with the current net-next.
>
>Jiri, the point I wanted to make that if indeed there's a bug in mlx5
>or flower, we will have to fix it for 4.14 and then these bits would
>have to be rebased when net-next is re-planted over net, I put "FWIW"
>before that, so maybe it doesn't W so much, we'll see.

The fix is still unrelated to this patchset.
