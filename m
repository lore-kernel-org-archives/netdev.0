From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: use compat helper functions in
 compat_sys_recvmmsg
Date: Fri, 11 Dec 2009 15:16:34 -0800 (PST)
Message-ID: <20091211.151634.38009658.davem@davemloft.net>
References: <20091210065914.GB4144@osiris.boeblingen.de.ibm.com>
	<20091210124640.GA20963@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762301AbZLKXQb@vger.kernel.org>
In-Reply-To: <20091210124640.GA20963@ghostprotocols.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 10 Dec 2009 10:46:40 -0200

> Em Thu, Dec 10, 2009 at 07:59:15AM +0100, Heiko Carstens escreveu:
>> From: Heiko Carstens <heiko.carstens@de.ibm.com>
>> 
>> Use (get|put)_compat_timespec helper functions to simplify the code.
>> 
>> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
>> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Nice cleanup, thanks!
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
