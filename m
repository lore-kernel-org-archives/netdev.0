From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time
 down to switchdev
Date: Mon, 12 Oct 2015 22:39:23 -0700
Message-ID: <CAE4R7bBW+LkanhJfwSHLCtYNP6pE3=LVfHjWE1_j14brhExtcQ@mail.gmail.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-4-git-send-email-sfeldma@gmail.com> <77EF4405DD4BB54AACCE7DB593DF6A9A9F6596@SJEXCHMB14.corp.ad.broadcom.com>
 <CAE4R7bANc4rT3X_pCO5SSvDre7vvZ3+0VY43PZu9cpv020uayw@mail.gmail.com>
 <20151010070434.GB1990@nanopsycho.orion> <20151010155619.GA14572@ketchup>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:34326 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJMFjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 01:39:43 -0400
Received: by obbda8 with SMTP id da8so5534527obb.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 22:39:43 -0700 (PDT)
In-Reply-To: <20151010155619.GA14572@ketchup>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2015 at 8:56 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:

> Scott, didn't you have a plan to add a struct device for the parent of
> switchdev ports?

I had sent out a rough RFC for a switch device in the last window.  I
have continued working on it, and I plan to send it very soon,
probably again as an RFC.
