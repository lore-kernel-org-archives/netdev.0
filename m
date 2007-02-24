From: Dirk <biecie547@gmail.com>
Subject: Re: Slow connection with RTL8168b/8111b
Date: Sat, 24 Feb 2007 12:15:46 +0100
Message-ID: <88ab4080702240315r320a0adeq4baa6d8fb140f22b@mail.gmail.com>
References: <88ab4080702210744s1ccf0c8cr504c4f007cc11062@mail.gmail.com>
	 <20070222080633.GA6612@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Edward Hsu" <edward_hsu@realtek.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:63142 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbXBXLPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 06:15:47 -0500
Received: by wx-out-0506.google.com with SMTP id h31so765769wxd
        for <netdev@vger.kernel.org>; Sat, 24 Feb 2007 03:15:47 -0800 (PST)
In-Reply-To: <20070222080633.GA6612@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/22/07, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Can you try the patch below against 2.6.21-rc1:
>
> http://www.fr.zoreil.com/people/francois/misc/20070221-2.6.21-rc1-r8169-test.patch

I tried running 2.6.21-rc1 with the patch you mentioned, but it still
has thesame speed problem. Building the driver with or without NAPI
support makes no difference.



Kind regards,
Dirk
