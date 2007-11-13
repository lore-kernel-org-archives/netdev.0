From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 13:54:21 -0500
Message-ID: <4739F2DD.5050802@rtr.ca>
References: <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113183925.GF17785@parisc-linux.org> <4739F069.6050102@rtr.ca> <20071113184902.GG17785@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, alsa-devel@alsa-project.org,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org, protasnb@gmail.com,
	linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113184902.GG17785@parisc-linux.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Tue, Nov 13, 2007 at 01:43:53PM -0500, Mark Lord wrote:
>
>> mkdir t
>> cd t
>> git clone 
>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
>> (wait half an hour)
>> /usr/bin/du -s linux-2.6
>> 522732  linux-2.6
> 
> You're assuming that everything in linux-2.6 was downloaded; that's
> not true.  Everything in linux-2.6/.git was downloaded; but then you do a
> checkout which happens to approximately double the size of the linux-2.6
> directory. 
..

Ah, I wondered why it took only half an hour to download.

..
> When you compare it to the 60MB tarballs that are published, it's really
> not that bad.
..

The tarballs I download are only 45MB.

Cheers
