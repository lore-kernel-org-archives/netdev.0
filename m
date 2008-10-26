From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: r8169 MAC addresses broken
Date: Sun, 26 Oct 2008 18:24:21 +0100
Message-ID: <4904A7C5.7090801@gmail.com>
References: <490380C8.6070003@simon.arlott.org.uk> <4903947A.3060206@gmail.com> <20081025223443.GA30913@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:50163 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbYJZRY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 13:24:28 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1634819fgg.17
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2008 10:24:25 -0700 (PDT)
In-Reply-To: <20081025223443.GA30913@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2008 12:34 AM, Francois Romieu wrote:
> It may go away if one comments out rtl_init_mac_address in rtl8169_init_one

Hmm, no. How can one restore eeprom contents without making a brick from the
notebook? I seem to have all zeroes in the eeprom mac address area.
