From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Tue, 20 Mar 2012 17:40:22 +0800
Message-ID: <CACVXFVN5O2S0hsnzHoi=LX+KAnccHc_F0SXq9-hMOXnaoUOdkg@mail.gmail.com>
References: <20120319151224.GA16031@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62800 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229Ab2CTJkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 05:40:23 -0400
In-Reply-To: <20120319151224.GA16031@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Mar 19, 2012 at 11:12 PM, Dave Jones <davej@redhat.com> wrote:
> We've had two reports of this use after free in Fedora now recently..

Could you provide output of 'dmesg' and 'lsusb -v' from the reported machine?



Thanks,
-- 
Ming Lei
