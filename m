From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: Soft lockups with dscape on wireless-dev tree
Date: Tue, 23 Jan 2007 15:49:05 -0500
Message-ID: <9e4733910701231249m2a766522ja6c139dd81040a58@mail.gmail.com>
References: <9e4733910701230910w79a7af45hff626e48a7091ffd@mail.gmail.com>
	 <200701231357.54921.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:47201 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933097AbXAWUtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 15:49:06 -0500
Received: by py-out-1112.google.com with SMTP id a29so851625pyi
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 12:49:05 -0800 (PST)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <200701231357.54921.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/23/07, Michael Wu <flamingice@sourmilk.net> wrote:
> On Tuesday 23 January 2007 12:10, Jon Smirl wrote:
> > I've hit this twice. This time I unplugged my USB hub which had the
> > device in it.
> >
> Please try the patch I posted earlier:
>
> http://marc.theaimsgroup.com/?l=linux-netdev&m=116841004113998&w=2

This patch appears to fix the problems I was having with Dscape soft lockup.
I tried all of the ways if failed previously and none of them lockup now.

> Also can be found here:
>
> http://kernel.org/git/?p=linux/kernel/git/jbenc/dscape.git;a=commitdiff_plain;h=e3973cb079b24875af1f196d03569ce7eb517c92;hp=f85c9f7b6a0fe662b95595c51aed92d784e93c5e
>
> -Michael Wu
>
>
>


-- 
Jon Smirl
jonsmirl@gmail.com
