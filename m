From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v5 20/21] rocker: make checkpatch -f clean
Date: Tue, 5 May 2015 13:01:07 -0700
Message-ID: <CAE4R7bAJi7a4f_me2V5Ea2w8TOeH1D-+ibHV-0bo5tDKF__-+g@mail.gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
	<1430847297-15728-21-git-send-email-sfeldma@gmail.com>
	<1430847947.3943.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:33553 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933015AbbEEUBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 16:01:08 -0400
Received: by qctx5 with SMTP id x5so9524981qct.0
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 13:01:07 -0700 (PDT)
In-Reply-To: <1430847947.3943.4.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 5, 2015 at 10:45 AM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2015-05-05 at 10:34 -0700, sfeldma@gmail.com wrote:
>> Well almost clean: ignore the CHECKs for space after cast operator.
>
> I think, because this uses relatively long identifiers,
> that you might as well ignore > 80 column lines length
> warnings.

Alright, I'll revert those.
