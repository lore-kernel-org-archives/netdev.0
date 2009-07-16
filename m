From: Trilok Soni <soni.trilok@gmail.com>
Subject: Re: [PATCH] Add mac resource support for w90p910
Date: Thu, 16 Jul 2009 18:39:52 +0530
Message-ID: <5d5443650907160609j742c407dpffaf818e5552a7e1@mail.gmail.com>
References: <4A5F21E2.90307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Russell King <linux@arm.linux.org.uk>,
	"Eric.miao" <eric.y.miao@gmail.com>
To: Wan ZongShun <mcuos.com@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:62432 "EHLO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860AbZGPNJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 09:09:55 -0400
Received: by qyk30 with SMTP id 30so65659qyk.33
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 06:09:52 -0700 (PDT)
In-Reply-To: <4A5F21E2.90307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wan,

On Thu, Jul 16, 2009 at 6:19 PM, Wan ZongShun<mcuos.com@gmail.com> wrote:
> +
> +struct platform_device w90p910_device_emc = {

static?

-- 
---Trilok Soni
http://triloksoni.wordpress.com
http://www.linkedin.com/in/triloksoni
