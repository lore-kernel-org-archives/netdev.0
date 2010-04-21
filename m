From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] Infiniband: Randomize local port allocation.
Date: Wed, 21 Apr 2010 16:19:28 -0700
Message-ID: <adabpdco0lb.fsf@roland-alpha.cisco.com>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>
	<20100412100816.5302.74919.sendpatchset@localhost.localdomain>
	<201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>
	<4BC41994.7030707@redhat.com> <4BC42FE0.4040601@redhat.com>
	<201004132207.GAJ52684.OJFtMQVFHOSFLO@I-love.SAKURA.ne.jp>
	<21DAC78125424ED291B5D6477CFF9657@amr.corp.intel.com>
	<201004140201.o3E21Aqn075978@www262.sakura.ne.jp>
	<195EB1AD388F455AA386EB214FCD09F4@amr.corp.intel.com>
	<201004150229.o3F2T4dZ054768@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sean.hefty@intel.com, amwang@redhat.com, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, davem@davemloft.net, ebiederm@xmission.com,
	linux-kernel@vger.kernel.org, rolandd@cisco.com
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201004150229.o3F2T4dZ054768@www262.sakura.ne.jp> (Tetsuo Handa's
	message of "Thu, 15 Apr 2010 11:29:04 +0900")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, applied this part of the patch -- I preferred this one since the
goto into the middle of a loop seemed worse than a goto out of the loop...
-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
