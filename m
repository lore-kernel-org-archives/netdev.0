From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: BUG: rwlock bad magic on CPU#1, NetworkManager/
Date: Sun, 24 May 2015 18:41:56 -0700
Message-ID: <20150525014156.GA1745@hudson.localdomain>
References: <20150513214939.GA4755@hudson.localdomain>
 <1431558331.6773.35.camel@redhat.com>
 <20150514083000.GA9624@hudson.localdomain>
 <20150519071528.GA5265@hudson.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Johannes Berg <johannes.berg@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150519071528.GA5265@hudson.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes,

On Tue, May 19, 2015 at 12:15:28AM -0700, Jeremiah Mahler wrote:
> Johannes,
> 
> You mentioned off-list that you might have a fix for this somewhere in
> mac80211-next.  Do you have any idea when this will make it in to -next?
> It is still broken as of -next 20150518.
> 
> -- 
> - Jeremiah Mahler

As of next-20150522 this bug is fixed.

Thanks Johannes.

-- 
- Jeremiah Mahler
