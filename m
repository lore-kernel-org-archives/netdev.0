From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Mon, 27 Aug 2012 18:44:28 +0200
Message-ID: <20120827164428.GA2269@netboy.at.omicron.at>
References: <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
 <20120823181117.GD2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD379@ORSMSX101.amr.corp.intel.com>
 <20120824065554.GB3261@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DDE99@ORSMSX101.amr.corp.intel.com>
 <20120825054846.GA2233@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DEF86@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57401 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779Ab2H0Qol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 12:44:41 -0400
Received: by bkwj10 with SMTP id j10so1321695bkw.19
        for <netdev@vger.kernel.org>; Mon, 27 Aug 2012 09:44:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <06DFBC1E25D8024DB214DC7F41A3CD34488DEF86@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Unfortunately, the way I've built the series makes it difficult to put those fixes before the re-factoring. The need for the design change drove the re-factor to give me the foundation. I'll make a note to myself to come up with something to apply to stable.

Hm, I didn't see anything here that looks like bug fix. Did I miss
something?  What causes the ifup/ifdown weirdness, anyhow?

(It seems hard to believe that it has something to do with the names
or locations of the various functions.)

Thanks,
Richard
