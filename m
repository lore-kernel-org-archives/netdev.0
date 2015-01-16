From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 1/2] switchdev: introduce switchdev notifier
Date: Fri, 16 Jan 2015 11:28:40 -0800
Message-ID: <CAE4R7bAnhOqrRtotRZPXFjKSQH7SPXF9kWUvdE4DdCsgB0bHOA@mail.gmail.com>
References: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@gmail.co>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	linus.luessing@web.de, Thomas Graf <tgraf@suug.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:52038 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756907AbbAPT2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 14:28:41 -0500
Received: by mail-wg0-f53.google.com with SMTP id x13so22215636wgg.12
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 11:28:40 -0800 (PST)
In-Reply-To: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 2:49 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> This patch introduces new notifier for purposes of exposing events which happen
> on switch driver side. The consumers of the event messages are mainly involved
> masters, namely bridge and ovs.
>
> Suggested-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
