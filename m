From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 6/6] rocker: use change upper info
Date: Wed, 26 Aug 2015 10:55:39 -0700
Message-ID: <CAE4R7bBLrDDhP79MT1qTPFo6ZJXTAhEe=UpWbtuFN=F+nU40WA@mail.gmail.com>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us> <1440606998-11072-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33202 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbHZRz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 13:55:59 -0400
Received: by obbhe7 with SMTP id he7so178501107obb.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 10:55:59 -0700 (PDT)
In-Reply-To: <1440606998-11072-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 9:36 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Since now information about changed upper is passed along, benefit from
> that and use this info directly.
>
> This also fixes possible issues that could happen when non-master device
> is added (current code does not distinguish between master and non-master
> upper device).
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
