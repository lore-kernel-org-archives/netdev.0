From: Maz The Northener <mazziesaccount@gmail.com>
Subject: patch "workflow" - what deferred state means?
Date: Mon, 7 Nov 2011 21:07:45 +0200
Message-ID: <CANhJrGNsyD1vsRA4xhgD3KrY9ZcdNOyM4JsM+kf71Pt9KTqh-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:43299 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab1KGTHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 14:07:45 -0500
Received: by pzk2 with SMTP id 2so57462pzk.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 11:07:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I sent a few versions of a patch to the netdev some days ago. I
recently stumbled upon patchwork website, and noticed that the latest
versions of my patches had "deferred" state. I tried searching for
what that means, but only thing I managed to find was Uboot project's
explanation. They used deferred state to mean that patch in question
depends on something not currently in source tree. I doubt that's the
case here though. Maybe it is because my patch was created against rc4
kernel.

I was just wondering if I could do some conclusion based on the state.
I naturally am keen to know if patch is rejected, or if it stil may
end up in kernel, or if there is something I could still do in order
to improve the situation? Maybe creating the patch against new 3.1
kernel would help you?

So is the different states of patches explained somewhere?

--Matti Vaittinen
