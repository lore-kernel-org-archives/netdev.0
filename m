From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Remove unneeded ovs_netdev_get_ifindex()
Date: Mon, 29 Apr 2013 11:07:15 -0700
Message-ID: <CAEP_g=8wjitQd3ViBLbo=gEMNQWPuDX2wkNi_+1wmYoyqO88ZA@mail.gmail.com>
References: <a59b1675cc29cd2897bdf1fb6ae34bfd0971fbb7.1366980015.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:58076 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754931Ab3D2SHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:07:36 -0400
Received: by mail-ie0-f198.google.com with SMTP id 9so34988840iec.5
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 11:07:35 -0700 (PDT)
In-Reply-To: <a59b1675cc29cd2897bdf1fb6ae34bfd0971fbb7.1366980015.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 26, 2013 at 5:40 AM, Thomas Graf <tgraf@suug.ch> wrote:
> The only user is get_dpifindex(), no need to redirect via the port
> operations.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I'll let David take this one directly since my tree is otherwise empty
and the merge window is coming up.

Acked-by: Jesse Gross <jesse@nicira.com>
