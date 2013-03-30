From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 0/6] Open vSwitch updates
Date: Fri, 29 Mar 2013 18:54:39 -0700
Message-ID: <CAEP_g=_nC2LDhVXKSFYRUm9LfNsAuoKNbvS+iFH+4Kb4ivEJ6Q@mail.gmail.com>
References: <cover.1364563346.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:35801 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757521Ab3C3BzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 21:55:01 -0400
Received: by mail-we0-f200.google.com with SMTP id d46so1316126wer.11
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 18:54:59 -0700 (PDT)
In-Reply-To: <cover.1364563346.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 29, 2013 at 6:46 AM, Thomas Graf <tgraf@suug.ch> wrote:
> A couple of small Open vSwitch fixes and cleanups that accumulated
> while working on larger pieces.
>
> The biggest change is the exposure of <linux/openvswitch.h> to user
> space to make the Netlink interface available without requiring every
> appliation to copy the header file from a source tree.

All applied, thank you very much.
