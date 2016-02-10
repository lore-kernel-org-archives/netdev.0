From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next 1/7] sock: struct proto hash function may error
Date: Tue, 9 Feb 2016 19:09:57 -0500
Message-ID: <CAEfhGiyJpo5MPUq5SnLGA922YoFV2ZnOb+BvabPWxW5eUtdq0w@mail.gmail.com>
References: <1455061153-7855-2-git-send-email-kraigatgoog@gmail.com>
	<201602100737.wrLlsIWe%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:33548 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbcBJAKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 19:10:00 -0500
Received: by mail-lb0-f193.google.com with SMTP id bc4so131951lbc.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 16:09:59 -0800 (PST)
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com. [209.85.215.54])
        by smtp.gmail.com with ESMTPSA id eb3sm56512lbc.31.2016.02.09.16.09.58
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 16:09:58 -0800 (PST)
Received: by mail-lf0-f54.google.com with SMTP id j78so2046426lfb.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 16:09:58 -0800 (PST)
In-Reply-To: <201602100737.wrLlsIWe%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 9, 2016 at 6:58 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Craig,
>
> [auto build test WARNING on net-next/master]
v3 will be the charm :\
