From: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 21 Jun 2016 10:18:30 -0700
Message-ID: <8a0e9fad-846a-5924-3e6b-348c2d6c2aec@linux.intel.com>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain> <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk> <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
 <20160618224549.GF32724@icarus.home.austad.us>
 <9a5abd48-4da3-945d-53c9-b6d37010ab0d@linux.intel.com>
 <20160620121838.GA5257@localhost.localdomain>
 <20160620123148.GA5846@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
 Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
 Takashi Sakamoto <o-takashi@sakamocchi.jp>, Arnd Bergmann <arnd@linaro.org>,
 linux-media@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20160620123148.GA5846@localhost.localdomain>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On 6/20/16 5:31 AM, Richard Cochran wrote:
> On Mon, Jun 20, 2016 at 02:18:38PM +0200, Richard Cochran wrote:
>> Documentation/sound/alsa/timestamping.txt says:
>
>    Examples of typestamping with HDaudio:
>
>    1. DMA timestamp, no compensation for DMA+analog delay
>    $ ./audio_time  -p --ts_type=1
>
> Where is this "audio_time" program of which you speak?

alsa-lib/test
