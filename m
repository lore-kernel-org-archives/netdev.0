From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Thu, 3 Mar 2011 13:19:50 -0500
Message-ID: <20110303181950.GD8969@tuxdriver.com>
References: <20110225222210.GA3618@tuxdriver.com>
 <AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
 <87fwr9jxya.fsf@cruithne.co.teklibre.org>
 <AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
 <8739n9ii7z.fsf@cruithne.co.teklibre.org>
 <AANLkTi=Cp7N4xqPyU6KWF6DOzFytxaA2BeoXhnhsZ6dp@mail.gmail.com>
 <87tyfph2az.fsf@cruithne.co.teklibre.org>
 <1299176168.2157.14.camel@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave =?iso-8859-1?Q?T=E4ht?= <d@taht.net>, sedat.dilek@gmail.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	bloat-devel@lists.bufferbloat.net, linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1299176168.2157.14.camel@tardy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2011 at 10:16:08AM -0800, Rick Jones wrote:
> > For wireless routers and cable home gateways especially, this research
> > shows that the total un-managed buffers in your system should be less
> > than 32.
> 
> Would it be a good thing to start describing these queues not so much in
> terms of packets but in terms of delay (or bandwidth X delay)?
> 
> Constants tend to live longer than they should, no matter how noble in
> birth.

Yes, it probably would -- that would be more meaningful between
different technologies and/or for technologies that might have variable
latencies due to shared media or whatnot.

Now, the question becomes what patches to propose to make that
happen... :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
