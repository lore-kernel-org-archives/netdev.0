From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next-2.6 2008-07-14
Date: Tue, 15 Jul 2008 09:48:49 -0400
Message-ID: <20080715134849.GA24361@tuxdriver.com>
References: <20080714192302.GA2541@tuxdriver.com> <20080714132918.30a1794f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4402 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbYGOOSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 10:18:51 -0400
Content-Disposition: inline
In-Reply-To: <20080714132918.30a1794f.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 01:29:18PM -0700, Randy Dunlap wrote:
> On Mon, 14 Jul 2008 15:23:02 -0400 John W. Linville wrote:
> 
> > Dave,
> > 
> > Here is one last(?) round of miscellaneous patches I hope to get into
> > 2.6.27.  There are mostly driver updates, including a sizable iwlwifi
> > set of changes.
> > 
> > Please let me know if there are problems!
> 
> Hi,
> Dare I ask what happened to the mac80211 kernel-doc patch?
> 
> Thanks,
> ~Randy

commit 6ef307bc561911c8cdda98ef3896b5982b602a43
Author: Randy Dunlap <randy.dunlap@oracle.com>
Date:   Thu Jul 3 13:52:18 2008 -0700

    mac80211: fix lots of kernel-doc
    
    Fix more than 50 kernel-doc warnings in ieee80211/mac80211 kernel-doc notati
    Fix a few typos also.
    
    Note: Some fields are marked as TBD and need to have their description
    corrected.
    
    Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville
linville@tuxdriver.com
