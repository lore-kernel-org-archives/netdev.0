From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next] openvswitch:: link upper device for port devices
Date: Tue, 30 Jul 2013 16:11:45 -0700
Message-ID: <CAEP_g=-6GZ7U8rxBztcBsndioxogd2fRXPnXyO9Mny0ojF0etQ@mail.gmail.com>
References: <1374840114-5622-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:51963 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758239Ab3G3XMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:12:06 -0400
Received: by mail-ob0-f171.google.com with SMTP id tb18so34899obb.16
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 16:12:06 -0700 (PDT)
In-Reply-To: <1374840114-5622-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 5:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Link upper device properly. That will make IFLA_MASTER filled up.
> Set the master to port 0 of the datapath under which the port belongs.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.

Sorry about the delay - I was waiting to see if the vxlan stuff would wrap up.
