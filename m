From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: ARGH MORE BUGS!!!
Date: Mon, 21 Feb 2005 21:34:18 +0100
Message-ID: <421A45CA.80001@rapidforum.com>
References: <421A3EB8.4050607@rapidforum.com> <20050221202854.GA26248@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050221202854.GA26248@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(s02) [21:05:13] root:~# cat /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables 
<batchcount> <limit> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
ip_fib_alias          14    226     16  226    1 : tunables  120   60    8 : slabdata      1      1 
      0
ip_fib_hash           14    119     32  119    1 : tunables  120   60    8 : slabdata      1      1 
      0
rpc_buffers            8      8   2048    2    1 : tunables   24   12    8 : slabdata      4      4 
      0
rpc_tasks              8     15    256   15    1 : tunables  120   60    8 : slabdata      1      1 
      0
rpc_inode_cache        0      0    512    7    1 : tunables   54   27    8 : slabdata      0      0 
      0
unix_sock             15     28    512    7    1 : tunables   54   27    8 : slabdata      4      4 
      0
ipt_hashlimit          0      0     64   61    1 : tunables  120   60    8 : slabdata      0      0 
      0
tcp_tw_bucket       3474   4464    128   31    1 : tunables  120   60    8 : slabdata    144    144 
    480
tcp_bind_bucket       11    226     16  226    1 : tunables  120   60    8 : slabdata      1      1 
      0
tcp_open_request     310    427     64   61    1 : tunables  120   60    8 : slabdata      7      7 
      0
inet_peer_cache      430    488     64   61    1 : tunables  120   60    8 : slabdata      8      8 
      0
secpath_cache          0      0    128   31    1 : tunables  120   60    8 : slabdata      0      0 
      0
xfrm_dst_cache         0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0 
      0
ip_dst_cache       10434  25410    256   15    1 : tunables  120   60    8 : slabdata   1694   1694 
      0
arp_cache              3     15    256   15    1 : tunables  120   60    8 : slabdata      1      1 
      0
raw_sock               5      7    512    7    1 : tunables   54   27    8 : slabdata      1      1 
      0
udp_sock               0      0    512    7    1 : tunables   54   27    8 : slabdata      0      0 
      0
tcp_sock            3218   3374   1152    7    2 : tunables   24   12    8 : slabdata    482    482 
     12
flow_cache             0      0    128   31    1 : tunables  120   60    8 : slabdata      0      0 
      0
dm-snapshot-in       128    140     56   70    1 : tunables  120   60    8 : slabdata      2      2 
      0
dm-snapshot-ex         0      0     24  156    1 : tunables  120   60    8 : slabdata      0      0 
      0
dm-crypt_io            0      0     76   52    1 : tunables  120   60    8 : slabdata      0      0 
      0
dm_tio                 0      0     16  226    1 : tunables  120   60    8 : slabdata      0      0 
      0
dm_io                  0      0     16  226    1 : tunables  120   60    8 : slabdata      0      0 
      0
scsi_cmd_cache       261    390    384   10    1 : tunables   54   27    8 : slabdata     39     39 
    184
cfq_ioc_pool           0      0     24  156    1 : tunables  120   60    8 : slabdata      0      0 
      0
cfq_pool               0      0    104   38    1 : tunables  120   60    8 : slabdata      0      0 
      0
crq_pool               0      0     56   70    1 : tunables  120   60    8 : slabdata      0      0 
      0
deadline_drq           0      0     52   75    1 : tunables  120   60    8 : slabdata      0      0 
      0
as_arq               665    793     64   61    1 : tunables  120   60    8 : slabdata     13     13 
    420
mqueue_inode_cache      1      7    512    7    1 : tunables   54   27    8 : slabdata      1      1 
      0
udf_inode_cache        0      0    368   11    1 : tunables   54   27    8 : slabdata      0      0 
      0
nfs_write_data        36     42    512    7    1 : tunables   54   27    8 : slabdata      6      6 
      0
nfs_read_data         32     35    512    7    1 : tunables   54   27    8 : slabdata      5      5 
      0
nfs_inode_cache        0      0    572    7    1 : tunables   54   27    8 : slabdata      0      0 
      0
nfs_page               0      0     64   61    1 : tunables  120   60    8 : slabdata      0      0 
      0
isofs_inode_cache      0      0    340   11    1 : tunables   54   27    8 : slabdata      0      0 
      0
fat_inode_cache        0      0    372   10    1 : tunables   54   27    8 : slabdata      0      0 
      0
fat_cache              0      0     20  185    1 : tunables  120   60    8 : slabdata      0      0 
      0
ext2_inode_cache    2687   4446    424    9    1 : tunables   54   27    8 : slabdata    494    494 
     10
journal_handle         0      0     20  185    1 : tunables  120   60    8 : slabdata      0      0 
      0
journal_head           0      0     48   81    1 : tunables  120   60    8 : slabdata      0      0 
      0
revoke_table           0      0     12  290    1 : tunables  120   60    8 : slabdata      0      0 
      0
revoke_record          0      0     16  226    1 : tunables  120   60    8 : slabdata      0      0 
      0
ext3_inode_cache       0      0    500    8    1 : tunables   54   27    8 : slabdata      0      0 
      0
ext3_xattr             0      0     48   81    1 : tunables  120   60    8 : slabdata      0      0 
      0
reiser_inode_cache    483    840    392   10    1 : tunables   54   27    8 : slabdata     84     84 
      0
dnotify_cache          0      0     20  185    1 : tunables  120   60    8 : slabdata      0      0 
      0
eventpoll_pwq          0      0     36  107    1 : tunables  120   60    8 : slabdata      0      0 
      0
eventpoll_epi          0      0    128   31    1 : tunables  120   60    8 : slabdata      0      0 
      0
kioctx                 0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0 
      0
kiocb                  0      0    128   31    1 : tunables  120   60    8 : slabdata      0      0 
      0
fasync_cache           0      0     16  226    1 : tunables  120   60    8 : slabdata      0      0 
      0
shmem_inode_cache     85    117    408    9    1 : tunables   54   27    8 : slabdata     13     13 
      0
posix_timers_cache      0      0    104   38    1 : tunables  120   60    8 : slabdata      0      0 
      0
uid_cache              5     61     64   61    1 : tunables  120   60    8 : slabdata      1      1 
      0
sgpool-128            52     57   2560    3    2 : tunables   24   12    8 : slabdata     19     19 
      0
sgpool-64             35     42   1280    3    1 : tunables   24   12    8 : slabdata     14     14 
      0
sgpool-32            292    294    640    6    1 : tunables   54   27    8 : slabdata     49     49 
    173
sgpool-16            247    280    384   10    1 : tunables   54   27    8 : slabdata     28     28 
    114
sgpool-8             321    345    256   15    1 : tunables  120   60    8 : slabdata     23     23 
    104
blkdev_ioc            71    135     28  135    1 : tunables  120   60    8 : slabdata      1      1 
      0
blkdev_queue          29     40    372   10    1 : tunables   54   27    8 : slabdata      4      4 
      0
blkdev_requests      662    783    148   27    1 : tunables  120   60    8 : slabdata     29     29 
    420
biovec-(256)         256    256   3072    2    2 : tunables   24   12    8 : slabdata    128    128 
      0
biovec-128           256    260   1536    5    2 : tunables   24   12    8 : slabdata     52     52 
      0
biovec-64            503    580    768    5    1 : tunables   54   27    8 : slabdata    116    116 
    158
biovec-16            478    495    256   15    1 : tunables  120   60    8 : slabdata     33     33 
    104
biovec-4             402    488     64   61    1 : tunables  120   60    8 : slabdata      8      8 
     44
biovec-1             857   4068     16  226    1 : tunables  120   60    8 : slabdata     18     18 
    404
bio                  791   1829    128   31    1 : tunables  120   60    8 : slabdata     59     59 
    300
file_lock_cache       20     43     92   43    1 : tunables  120   60    8 : slabdata      1      1 
      0
sock_inode_cache    3190   3360    384   10    1 : tunables   54   27    8 : slabdata    336    336 
     54
skbuff_head_cache  98736 109950    256   15    1 : tunables  120   60    8 : slabdata   7330   7330 
    420
sock                   7     20    384   10    1 : tunables   54   27    8 : slabdata      2      2 
      0
proc_inode_cache      19     48    328   12    1 : tunables   54   27    8 : slabdata      4      4 
      0
sigqueue             149    216    148   27    1 : tunables  120   60    8 : slabdata      8      8 
      0
radix_tree_node    55690  56182    276   14    1 : tunables   54   27    8 : slabdata   4013   4013 
     27
bdev_cache            33     42    512    7    1 : tunables   54   27    8 : slabdata      6      6 
      0
mnt_cache             20     31    128   31    1 : tunables  120   60    8 : slabdata      1      1 
      0
inode_cache         1099   1104    312   12    1 : tunables   54   27    8 : slabdata     92     92 
      0
dentry_cache        7375  10388    140   28    1 : tunables  120   60    8 : slabdata    371    371 
      0
filp                6532   6945    256   15    1 : tunables  120   60    8 : slabdata    463    463 
      0
names_cache           40     40   4096    1    1 : tunables   24   12    8 : slabdata     40     40 
     12
idr_layer_cache       77    116    136   29    1 : tunables  120   60    8 : slabdata      4      4 
      0
buffer_head        68550  68550     52   75    1 : tunables  120   60    8 : slabdata    914    914 
      0
mm_struct             61     72    640    6    1 : tunables   54   27    8 : slabdata     12     12 
      0
vm_area_struct      1980   2745     88   45    1 : tunables  120   60    8 : slabdata     61     61 
    120
fs_cache              46    183     64   61    1 : tunables  120   60    8 : slabdata      3      3 
      0
files_cache           46     63    512    7    1 : tunables   54   27    8 : slabdata      9      9 
      0
signal_cache         115    150    256   15    1 : tunables  120   60    8 : slabdata     10     10 
      0
sighand_cache         90     95   1408    5    2 : tunables   24   12    8 : slabdata     19     19 
      0
task_struct          106    108   1280    3    1 : tunables   24   12    8 : slabdata     36     36 
      0
anon_vma             499    870     12  290    1 : tunables  120   60    8 : slabdata      3      3 
      0
pgd                   90    238     32  119    1 : tunables  120   60    8 : slabdata      2      2 
      0
pmd                   62     62   4096    1    1 : tunables   24   12    8 : slabdata     62     62 
      0
size-131072(DMA)       0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0 
      0
size-131072            0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0 
      0
size-65536(DMA)        0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0 
      0
size-65536             0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0 
      0
size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0 
      0
size-32768             0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0 
      0
size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0 
      0
size-16384             0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0 
      0
size-8192(DMA)         0      0   8192    1    2 : tunables    8    4    0 : slabdata      0      0 
      0
size-8192              8      8   8192    1    2 : tunables    8    4    0 : slabdata      8      8 
      0
size-4096(DMA)         0      0   4096    1    1 : tunables   24   12    8 : slabdata      0      0 
      0
size-4096           2509   2509   4096    1    1 : tunables   24   12    8 : slabdata   2509   2509 
      0
size-2048(DMA)         0      0   2048    2    1 : tunables   24   12    8 : slabdata      0      0 
      0
size-2048            290    326   2048    2    1 : tunables   24   12    8 : slabdata    160    163 
     60
size-1024(DMA)         0      0   1024    4    1 : tunables   54   27    8 : slabdata      0      0 
      0
size-1024            308    324   1024    4    1 : tunables   54   27    8 : slabdata     81     81 
     27
size-512(DMA)          0      0    512    8    1 : tunables   54   27    8 : slabdata      0      0 
      0
size-512           95390  97064    512    8    1 : tunables   54   27    8 : slabdata  12133  12133 
    216
size-256(DMA)          0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0 
      0
size-256             272    300    256   15    1 : tunables  120   60    8 : slabdata     20     20 
      0
size-128(DMA)          0      0    128   31    1 : tunables  120   60    8 : slabdata      0      0 
      0
size-128            1601   1674    128   31    1 : tunables  120   60    8 : slabdata     54     54 
      0
size-64(DMA)           0      0     64   61    1 : tunables  120   60    8 : slabdata      0      0 
      0
size-64            18303  23058     64   61    1 : tunables  120   60    8 : slabdata    378    378 
     60
size-32(DMA)           0      0     32  119    1 : tunables  120   60    8 : slabdata      0      0 
      0
size-32             7614  10591     32  119    1 : tunables  120   60    8 : slabdata     89     89 
      0
kmem_cache           135    135    256   15    1 : tunables  120   60    8 : slabdata      9      9 
      0


Francois Romieu wrote:
> Christian Schmid <webmaster@rapidforum.com> :
> [...]
> 
>>But now I hit another BUG: After I have managed to create 4500 sockets, 10 
>>minutes later an interesting phenomenon appeared: It locks for 5 seconds 
>>every 60 seconds. I first thought this was something in my program but I 
>>can do what I want, I wasn't able to fix this. Even a restart of my program 
>>didnt help. It even appears with 400 connections. Then I despairedly just 
>>restarted the system and: It was gone. So what is THIS?
> 
> 
> What about monitoring /proc/slabinfo and vmstat output (with heavy renicing) ?
> 
> --
> Ueimor
> 
> 
