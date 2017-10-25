From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] ss: add detail explains of -m, -o, -e and -i
 options in ss man page
Date: Wed, 25 Oct 2017 08:37:06 +0200
Message-ID: <20171025083706.50497c40@shemminger-XPS-13-9360>
References: <CAG3TDc0XxtkA5TU_GDzdZv1ujuqf09e9kBYQm2p5QGbppt7efw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc
To: peng yu <yupeng0921@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:46718 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdJYGhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 02:37:23 -0400
Received: by mail-wr0-f194.google.com with SMTP id l1so22840953wrc.3
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 23:37:22 -0700 (PDT)
In-Reply-To: <CAG3TDc0XxtkA5TU_GDzdZv1ujuqf09e9kBYQm2p5QGbppt7efw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Oct 2017 17:13:30 -0700
peng yu <yupeng0921@gmail.com> wrote:

> +.SH Additional explain of -m, -o, -e and -i options
> +Some fields may have different meanings if the netowrk protocl is
> different. Below explain focus on tcp protocol.

Thank you for the patch.
Some formatting and style changes should be done before I accept it.
First, the SECTIONS in man pages are usually terse and all upper case
(back to Unix man page style).  Why not just put the additional text as a second
paragraph on the part that explains the first option?

Also, please run all manual page submissions through a spell checker.
The ispell program is one option.

Please resubmit
